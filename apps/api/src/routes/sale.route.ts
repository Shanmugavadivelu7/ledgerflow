import { Router } from "express";

import {
  createSaleHandler,
  getSalesHandler,
  getSaleByIdHandler,
  getTodaySalesHandler,
  getSalesByCustomerHandler,
  getSalesByDateHandler,
  deleteSaleHandler,
} from "../controllers/sale.controller.js";

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

router.get(
  "/today",
  asyncHandler(getTodaySalesHandler)
);

router.get(
  "/customer/:customerId",
  asyncHandler(getSalesByCustomerHandler)
);

router.get(
  "/date/:date",
  asyncHandler(getSalesByDateHandler)
);

router.get(
  "/:id",
  asyncHandler(getSaleByIdHandler)
);

router.delete(
  "/:id",
  asyncHandler(deleteSaleHandler)
);

export default router;