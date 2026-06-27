import { Router } from "express";

import {
  createCustomerHandler,
  getCustomersHandler,
} from "../controllers/customer.controller.js";

const router = Router();

router.post(
  "/",
  createCustomerHandler
);

router.get(
  "/",
  getCustomersHandler
);

export default router;