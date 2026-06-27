import type { Request, Response } from "express";

import {
  createCustomer,
  getCustomers,
} from "../services/customer.service.js";

export async function createCustomerHandler(
  req: Request,
  res: Response
) {
  const { name, phone } = req.body;

  const customer = await createCustomer(
    name,
    phone
  );

  return res.status(201).json(customer);
}

export async function getCustomersHandler(
  _req: Request,
  res: Response
) {
  const customers = await getCustomers();

  return res.json(customers);
}