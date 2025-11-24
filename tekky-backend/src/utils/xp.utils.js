export function calculateLevel(xp) {
  return Math.floor(Math.sqrt(xp / 50));
}

export function nextLevelXP(level) {
  return (level + 1) * (level + 1) * 50;
}
