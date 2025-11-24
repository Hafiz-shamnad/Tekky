import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import { getFeed, createPost, toggleLike } from "../controllers/post.controller.js";

const router = Router();

router.get("/", getFeed);
router.post("/", auth, createPost);
router.post("/:postId/like", auth, toggleLike);

export default router;
