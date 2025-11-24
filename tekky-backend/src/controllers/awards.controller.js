import prisma from "../config/db.js";
import { calculateLevel } from "../utils/xp.utils.js";

export async function addXP(userId, amount) {
  const user = await prisma.user.update({
    where: { id: userId },
    data: { xp: { increment: amount } },
  });

  const newLevel = calculateLevel(user.xp);

  if (newLevel !== user.level) {
    await prisma.user.update({
      where: { id: userId },
      data: { level: newLevel },
    });
  }

  return newLevel;
}

export async function giveDailyLoginXP(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { xp: true, level: true, lastDailyXP: true },
  });

  const now = new Date();
  const today = now.toISOString().split("T")[0]; // "2025-01-11"

  // If user has claimed XP today → no reward
  if (user.lastDailyXP) {
    const lastDay = user.lastDailyXP.toISOString().split("T")[0];
    if (lastDay === today) {
      return { xpGained: 0, alreadyClaimed: true };
    }
  }

  // Give XP reward + update lastDailyXP to today
  const updated = await prisma.user.update({
    where: { id: userId },
    data: {
      xp: { increment: 5 },
      lastDailyXP: now,
    },
  });

  const newLevel = calculateLevel(updated.xp);

  // If level changed, update it
  if (newLevel !== updated.level) {
    await prisma.user.update({
      where: { id: userId },
      data: { level: newLevel },
    });
  }

  return { xpGained: 5, alreadyClaimed: false };
}
