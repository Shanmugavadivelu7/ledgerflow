import { Router } from "express";
import { getDashboardHandler } from "../controllers/dashboard.controller.js";

const router = Router();

router.get("/", getDashboardHandler);

export default router;