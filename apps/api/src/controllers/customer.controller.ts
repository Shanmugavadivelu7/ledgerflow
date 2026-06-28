import type { Request, Response } from "express";

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

  return res.status(201).json(customer);
}

export async function getCustomersHandler(
  _req: Request,
  res: Response
) {
  const customers = await getCustomers();

  return res.status(200).json(customers);
}