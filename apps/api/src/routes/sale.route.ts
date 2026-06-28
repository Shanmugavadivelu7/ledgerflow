import { Router } from "express";
import { createSaleHandler } from "../controllers/sale.controller.js";
import { getSalesHandler } from "../controllers/sale.controller.js";
import { asyncHandler } from "../utils/async-handler.js";

const router = Router();

router.post(
  "/",
  asyncHandler(createSaleHandler)
);

router.get(
  "/",
  asyncHandler(getSalesHandler)
);
export default router;