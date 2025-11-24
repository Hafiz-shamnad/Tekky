import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import morgan from "morgan";
dotenv.config();

const app = express();

app.use(cors());
app.use(morgan("dev"));
app.use(express.json());

import authRoutes from "./routes/auth.routes.js";
import postRoutes from "./routes/post.routes.js";
import commentRoutes from "./routes/comment.routes.js";
import profileRoutes from "./routes/profile.routes.js";
import ideasRoutes from "./routes/ideas.routes.js";

app.use("/api/auth", authRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/comments", commentRoutes);
app.use("/api/profile", profileRoutes)
app.use("/api/ideas", ideasRoutes);

export default app;
