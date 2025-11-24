import prisma from "../config/db.js";

/**
 * GET /api/profile/:userId
 * Public profile with counts
 */
export const getProfile = async (req, res) => {
  const { userId } = req.params;

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      username: true,
      name: true,
      email: true,
      avatarUrl: true,
      bio: true,
      createdAt: true,
    },
  });

  if (!user) return res.status(404).json({ message: "User not found" });

  const postsCount = await prisma.post.count({ where: { authorId: userId } });
  const followersCount = await prisma.follow.count({ where: { followingId: userId } });
  const followingCount = await prisma.follow.count({ where: { followerId: userId } });

  return res.json({
    ...user,
    counts: { posts: postsCount, followers: followersCount, following: followingCount },
  });
};

/**
 * GET /api/profile/me
 */
export const getMyProfile = async (req, res) => {
  const userId = req.user.userId;

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      username: true,
      name: true,
      email: true,
      avatarUrl: true,
      bio: true,
      createdAt: true,
    },
  });

  if (!user) return res.status(404).json({ message: "User not found" });

  const postsCount = await prisma.post.count({ where: { authorId: userId } });
  const followersCount = await prisma.follow.count({ where: { followingId: userId } });
  const followingCount = await prisma.follow.count({ where: { followerId: userId } });

  return res.json({
    ...user,
    counts: { posts: postsCount, followers: followersCount, following: followingCount },
  });
};

/**
 * PUT /api/profile
 * Body: { username?, name?, avatarUrl?, bio? }
 */
export const updateProfile = async (req, res) => {
  const userId = req.user.userId;
  const { username, name, avatarUrl, bio } = req.body;

  // Optional: validate username uniqueness
  if (username) {
    const existing = await prisma.user.findUnique({ where: { username } });
    if (existing && existing.id !== userId) {
      return res.status(400).json({ message: "Username already taken" });
    }
  }

  const updated = await prisma.user.update({
    where: { id: userId },
    data: { username, name, avatarUrl, bio },
    select: {
      id: true,
      username: true,
      name: true,
      email: true,
      avatarUrl: true,
      bio: true,
      createdAt: true,
    },
  });

  return res.json(updated);
};

/**
 * GET /api/profile/:userId/posts?limit=10&cursor=<id>
 */
export const getUserPosts = async (req, res) => {
  const { userId } = req.params;
  const limit = parseInt(req.query.limit) || 10;
  const cursor = req.query.cursor || null;

  let posts;
  if (cursor) {
    posts = await prisma.post.findMany({
      where: { authorId: userId },
      take: limit,
      skip: 1,
      cursor: { id: cursor },
      orderBy: { createdAt: "desc" },
      include: { author: true, comments: true, likes: true },
    });
  } else {
    posts = await prisma.post.findMany({
      where: { authorId: userId },
      take: limit,
      orderBy: { createdAt: "desc" },
      include: { author: true, comments: true, likes: true },
    });
  }

  const nextCursor = posts.length ? posts[posts.length - 1].id : null;
  return res.json({ posts, nextCursor });
};

/**
 * POST /api/profile/:userId/follow
 */
export const followUser = async (req, res) => {
  const userId = req.user.userId;
  const { userId: targetId } = req.params;

  if (userId === targetId) return res.status(400).json({ message: "Cannot follow yourself" });

  try {
    await prisma.follow.create({
      data: { followerId: userId, followingId: targetId },
    });
  } catch (err) {
    // unique constraint -> already following
  }

  const followersCount = await prisma.follow.count({ where: { followingId: targetId } });
  return res.json({ message: "Followed", followersCount });
};

/**
 * POST /api/profile/:userId/unfollow
 */
export const unfollowUser = async (req, res) => {
  const userId = req.user.userId;
  const { userId: targetId } = req.params;

  await prisma.follow.deleteMany({
    where: { followerId: userId, followingId: targetId },
  });

  const followersCount = await prisma.follow.count({ where: { followingId: targetId } });
  return res.json({ message: "Unfollowed", followersCount });
};

/**
 * GET /api/profile/:userId/followers
 * GET /api/profile/:userId/following
 */
export const getFollowers = async (req, res) => {
  const { userId } = req.params;
  const followers = await prisma.follow.findMany({
    where: { followingId: userId },
    include: { follower: { select: { id: true, username: true, name: true, avatarUrl: true } } },
    orderBy: { createdAt: "desc" },
  });

  return res.json(followers.map(f => f.follower));
};

export const getFollowing = async (req, res) => {
  const { userId } = req.params;
  const following = await prisma.follow.findMany({
    where: { followerId: userId },
    include: { following: { select: { id: true, username: true, name: true, avatarUrl: true } } },
    orderBy: { createdAt: "desc" },
  });

  return res.json(following.map(f => f.following));
};
