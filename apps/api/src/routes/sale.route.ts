import { Router } from "express";
import { createSaleHandler } from "../controllers/sale.controller.js";
import { getSalesHandler } from "../controllers/sale.controller.js";
const router = Router();

router.post("/", createSaleHandler);
router.get("/", getSalesHandler);

export default router;