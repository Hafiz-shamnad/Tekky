import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import {
  addComment,
  getComments,
  deleteComment,
} from "../controllers/comment.controller.js";

const router = Router();

// Fetch comments for a post
router.get("/:postId", getComments);

// Add comment to a post
router.post("/:postId", auth, addComment);

// Delete comment
router.delete("/:commentId", auth, deleteComment);

export default router;
