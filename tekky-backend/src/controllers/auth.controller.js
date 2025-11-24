import prisma from "../config/db.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { createAccessToken, createRefreshToken, hashToken } from "../utils/tokens.utils.js";

/**
 * POST /api/auth/login
 * Body: { email, password }
 * Returns: { accessToken, refreshToken }
 */
export const login = async (req, res) => {
  const { identifier, password } = req.body;

  // Find user by email OR username
  const user = await prisma.user.findFirst({
    where: {
      OR: [
        { email: identifier },
        { username: identifier }
      ]
    }
  });

  if (!user) {
    return res.status(400).json({ message: "Invalid credentials" });
  }

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) {
    return res.status(400).json({ message: "Invalid credentials" });
  }

  // ------------------------------
  // ⭐ DAILY LOGIN XP LOGIC
  // ------------------------------
  const now = new Date();
  let xpGained = 0;
  let alreadyClaimed = false;

  if (!user.lastDailyXP || user.lastDailyXP.toISOString().split("T")[0] !== now.toISOString().split("T")[0]) {
    // Today login reward
    xpGained = 5;

    await prisma.user.update({
      where: { id: user.id },
      data: {
        xp: { increment: 5 },
        lastDailyXP: now,
      },
    });

  } else {
    alreadyClaimed = true;
  }

  // ------------------------------
  // ⭐ Level update after XP change
  // ------------------------------
  const updated = await prisma.user.findUnique({ where: { id: user.id } });

  const xpTotal = updated.xp;
  const level = Math.floor(xpTotal / 100) + 1;

  if (level !== updated.level) {
    await prisma.user.update({
      where: { id: user.id },
      data: { level },
    });
  }

  // ------------------------------

  const accessToken = createAccessToken(user);
  const { rawToken } = await createRefreshToken(user.id, 30);

  return res.json({
    accessToken,
    refreshToken: rawToken,

    dailyXP: xpGained,
    alreadyClaimed,
    newXP: xpTotal,
    newLevel: level,

    user: {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
    },
  });
};


/**
 * POST /api/auth/refresh
 * Body: { refreshToken }
 * Returns: { accessToken, refreshToken } (rotated)
 */
export const refresh = async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken)
    return res.status(400).json({ message: "No refresh token provided" });

  const tokenHash = hashToken(refreshToken);

  const existing = await prisma.refreshToken.findFirst({
    where: { tokenHash },
  });

  if (!existing) return res.status(401).json({ message: "Invalid refresh token" });
  if (existing.revoked)
    return res.status(401).json({ message: "Refresh token revoked" });
  if (existing.expiresAt < new Date())
    return res.status(401).json({ message: "Refresh token expired" });

  // get user
  const user = await prisma.user.findUnique({
    where: { id: existing.userId },
  });

  if (!user) return res.status(401).json({ message: "Invalid refresh token" });

  // rotate token
  const { rawToken: newRawToken, dbToken } = await createRefreshToken(
    user.id,
    30
  );

  await prisma.refreshToken.update({
    where: { id: existing.id },
    data: { revoked: true, replacedById: dbToken.id },
  });

  const accessToken = createAccessToken(user);

  return res.json({
    accessToken,
    refreshToken: newRawToken,

    // 🔥 FIX: include user info so Flutter gets `user.id`
    user: {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      xp: user.xp,
      level: user.level,
    },
  });
};

/**
 * POST /api/auth/logout
 * Body: { refreshToken } OR optionally read cookie
 * Revokes the provided refresh token
 */
export const logout = async (req, res) => {
  const { refreshToken } = req.body;
  console.log("BODY:", req.body);
  if (!refreshToken) return res.status(400).json({ message: "No refresh token provided" });

  const tokenHash = hashToken(refreshToken);
  const existing = await prisma.refreshToken.findFirst({ where: { tokenHash } });

  if (existing) {
    await prisma.refreshToken.update({
      where: { id: existing.id },
      data: { revoked: true },
    });
  }

  return res.json({ message: "Logged out" });
};

export const register = async (req, res) => {
  const { name, username, email, password } = req.body;

  if (!name || !username || !email || !password)
    return res.status(400).json({ message: "All fields are required" });

  // Check email exists
  const existing_email = await prisma.user.findUnique({ where: { email } });
  if (existing_email) {
    return res.status(400).json({ message: "Email already registered" });
  }

  const existing_username = await prisma.user.findUnique({ where: { email } });
  if (existing_username) {
    return res.status(400).json({ message: "username already registered" });
  }

  const hashed = await bcrypt.hash(password, 12);

  const user = await prisma.user.create({
    data: { name, username, email, password: hashed },
  });

  const accessToken = createAccessToken(user);
  const { rawToken: refreshToken } = await createRefreshToken(user.id, 30);

  return res.status(201).json({
    message: "Account created successfully",
    user: {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
    },
    accessToken,
    refreshToken,
  });
};

export const checkUsername = async (req, res) => {
  const { username } = req.query;

  if (!username || username.trim().length < 3) {
    return res.status(400).json({ available: false, message: "Invalid username" });
  }

  const existing = await prisma.user.findUnique({
    where: { username },
  });

  return res.json({ available: !existing });
};
