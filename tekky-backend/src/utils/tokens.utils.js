import crypto from "crypto";
import jwt from "jsonwebtoken";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export const createAccessToken = (user) => {
  // minimal payload — keep small
  return jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
    expiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || "15m",
  });
};

export const generateRefreshTokenString = () => {
  // return a secure random string (we'll send this raw to client)
  return crypto.randomBytes(48).toString("hex");
};

export const hashToken = (token) => {
  return crypto.createHash("sha256").update(token).digest("hex");
};

// create and store refresh token in DB (returns raw token to client)
export const createRefreshToken = async (userId, days = 30, replacedById = null) => {
  const token = generateRefreshTokenString();
  const tokenHash = hashToken(token);
  const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);

  const rt = await prisma.refreshToken.create({
    data: {
      tokenHash,
      userId,
      expiresAt,
      replacedById,
    },
  });

  return { rawToken: token, dbToken: rt };
};

// revoke refresh token by id
export const revokeTokenById = async (id) => {
  await prisma.refreshToken.update({
    where: { id },
    data: { revoked: true },
  });
};
