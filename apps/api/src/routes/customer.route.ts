import { Router } from "express";
import { asyncHandler } from "../utils/async-handler.js";

import {
  createCustomerHandler,
  getCustomersHandler,
} from "../controllers/customer.controller.js";

const router = Router();

router.post(
  "/",
  asyncHandler(createCustomerHandler)
);

router.get(
  "/",
  asyncHandler(getCustomersHandler)
);

export default router;