import prisma from "../config/db.js";

// GET comments for a post
export const getComments = async (req, res) => {
  const { postId } = req.params;

  const comments = await prisma.comment.findMany({
    where: { postId },
    include: { author: true },
    orderBy: { createdAt: "asc" },
  });

  return res.json(comments);
};

// POST a new comment
export const addComment = async (req, res) => {
  const { postId } = req.params;
  const { content } = req.body;
  const userId = req.user.userId;

  if (!content || content.trim() === "") {
    return res.status(400).json({ message: "Content is required" });
  }

  const comment = await prisma.comment.create({
    data: {
      content,
      postId,
      authorId: userId,
    },
    include: { author: true },
  });

  return res.json(comment);
};

// DELETE a comment
export const deleteComment = async (req, res) => {
  const { commentId } = req.params;
  const userId = req.user.userId;

  const comment = await prisma.comment.findUnique({
    where: { id: commentId },
  });

  if (!comment) {
    return res.status(404).json({ message: "Comment not found" });
  }

  if (comment.authorId !== userId) {
    return res.status(403).json({ message: "Not allowed" });
  }

  await prisma.comment.delete({
    where: { id: commentId },
  });

  return res.json({ message: "Comment deleted" });
};
