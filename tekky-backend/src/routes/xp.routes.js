import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import prisma from "../config/db.js";

const router = Router();

/**
 * GET /api/xp/me
 * Returns: XP, level, streak, lastDailyXP
 */
router.get("/me", auth, async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.userId },
    select: {
      xp: true,
      level: true,
      lastDailyXP: true,
    },
  });

  res.json(user);
});

/**
 * POST /api/xp/claim-daily
 * Forces XP claim (if not claimed today)
 * Useful for manual claim button.
 */
router.post("/claim-daily", auth, async (req, res) => {
  const userId = req.user.userId;

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      xp: true,
      level: true,
      lastDailyXP: true,
    },
  });

  const now = new Date();
  const today = now.toISOString().split("T")[0];

  if (user.lastDailyXP && user.lastDailyXP.toISOString().split("T")[0] === today) {
    return res.json({
      xpGained: 0,
      alreadyClaimed: true,
    });
  }

  // Give XP
  const updated = await prisma.user.update({
    where: { id: userId },
    data: {
      xp: { increment: 5 },
      lastDailyXP: now,
    },
  });

  const newLevel = Math.floor(updated.xp / 100) + 1;

  if (newLevel !== updated.level) {
    await prisma.user.update({
      where: { id: userId },
      data: { level: newLevel },
    });
  }

  res.json({
    xpGained: 5,
    alreadyClaimed: false,
    xp: updated.xp,
    level: newLevel,
  });
});

export default router;
