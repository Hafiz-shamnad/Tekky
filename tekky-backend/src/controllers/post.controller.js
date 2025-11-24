import prisma from "../config/db.js";

// ✔️ MOVE FORMATTER OUTSIDE — GLOBAL REUSABLE FUNCTION
const formatPost = (post, userId) => ({
  id: post.id,
  content: post.content,
  createdAt: post.createdAt,
  likesCount: post.likes.length,
  commentsCount: post.comments.length,
  isLiked: post.likes.some((l) => l.userId === userId),

  authorId: post.author.id,
  authorName: post.author.name,
  authorUsername: post.author.username,
  authorAvatarUrl: post.author.avatarUrl,
});

// ----------------------------------------------------------
// GET FEED
// ----------------------------------------------------------
export const getFeed = async (req, res) => {
  const limit = parseInt(req.query.limit) || 10;
  const cursor = req.query.cursor || null;
  const userId = req.user?.userId || null; // safe fallback

  let posts;

  if (cursor) {
    posts = await prisma.post.findMany({
      take: limit,
      skip: 1,
      cursor: { id: cursor },
      orderBy: { createdAt: "desc" },
      include: {
        author: true,
        comments: true,
        likes: true,
      },
    });
  } else {
    posts = await prisma.post.findMany({
      take: limit,
      orderBy: { createdAt: "desc" },
      include: {
        author: true,
        comments: true,
        likes: true,
      },
    });
  }

  const nextCursor = posts.length > 0 ? posts[posts.length - 1].id : null;

  return res.json({
    posts: posts.map((p) => formatPost(p, userId)),
    nextCursor,
  });
};

// ----------------------------------------------------------
// CREATE POST
// ----------------------------------------------------------
export const createPost = async (req, res) => {
  const userId = req.user.userId;

  const post = await prisma.post.create({
    data: {
      content: req.body.content,
      authorId: userId,
    },
    include: {
      author: true,
      comments: true,
      likes: true,
    },
  });

  return res.json(formatPost(post, userId));
};

// ----------------------------------------------------------
// TOGGLE LIKE
// ----------------------------------------------------------
export const toggleLike = async (req, res) => {
  const { postId } = req.params;
  const userId = req.user.userId;

  const existing = await prisma.like.findUnique({
    where: { postId_userId: { postId, userId } },
  });

  if (existing) {
    await prisma.like.delete({ where: { id: existing.id } });
  } else {
    await prisma.like.create({ data: { postId, userId } });
  }

  const updatedPost = await prisma.post.findUnique({
    where: { id: postId },
    include: {
      author: true,
      comments: true,
      likes: true,
    },
  });

  return res.json(formatPost(updatedPost, userId));
};
