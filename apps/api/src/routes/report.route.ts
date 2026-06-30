import { Router } from "express";

import { getReportHandler } from "../controllers/report.controller.js";
import { asyncHandler } from "../utils/async-handler.js";

const router = Router();

router.get(
  "/",
  asyncHandler(getReportHandler)
);

export default router;