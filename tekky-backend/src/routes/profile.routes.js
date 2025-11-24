import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import {
  getProfile,
  getMyProfile,
  updateProfile,
  getUserPosts,
  followUser,
  unfollowUser,
  getFollowers,
  getFollowing,
} from "../controllers/profile.controller.js";

const router = Router();

router.get("/me", auth, getMyProfile);
router.get("/:userId", getProfile);
router.put("/", auth, updateProfile);

router.get("/:userId/posts", getUserPosts);

router.post("/:userId/follow", auth, followUser);
router.post("/:userId/unfollow", auth, unfollowUser);

router.get("/:userId/followers", getFollowers);
router.get("/:userId/following", getFollowing);

export default router;
