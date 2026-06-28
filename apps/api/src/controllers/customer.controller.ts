import type { Request, Response } from "express";
import { successResponse } from "../utils/response.js";
import { createCustomerSchema } from "../validators/customer.validator.js";

import {
  createCustomer,
  getCustomers,
} from "../services/customer.service.js";

export async function createCustomerHandler(
  req: Request,
  res: Response
) {
  const data = createCustomerSchema.parse(req.body);

  const customer = await createCustomer(
    data.name,
    data.phone
  );
return successResponse(
  res,
  customer,
  "Customer created successfully",
  201
);
}

export async function getCustomersHandler(
  _req: Request,
  res: Response
) {
  const customers = await getCustomers();
return successResponse(
  res,
  customers,
  "Customers fetched successfully"
);
}