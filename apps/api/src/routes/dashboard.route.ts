import { Router } from "express";
import { getDashboardHandler } from "../controllers/dashboard.controller.js";
import { asyncHandler } from "../utils/async-handler.js";

const router = Router();

router.get(
  "/",
  asyncHandler(getDashboardHandler)
);
export default router;