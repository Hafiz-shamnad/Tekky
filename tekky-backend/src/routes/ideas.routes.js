import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import {
  getIdeas,
  getIdeaById,
  createIdea,
  sendInterest
} from "../controllers/idea.controller.js";

const router = Router();

router.get("/", getIdeas);
router.get("/:id", getIdeaById);

// protected
router.post("/", auth, createIdea);
router.post("/:id/interest", auth, sendInterest);

export default router;
