import type { Request, Response } from "express";
import { createSale } from "../services/sale.service.js";
import { getSales } from "../services/sale.service.js";
export async function createSaleHandler(
  req: Request,
  res: Response
) {
  const {
    customerId,
    paymentStatus,
    items,
  } = req.body;

  const sale = await createSale(
    customerId,
    paymentStatus,
    items
  );

  return res.status(201).json(sale);
}

export async function getSalesHandler(
  _req: Request,
  res: Response
) {
  const sales = await getSales();

  return res.json(sales);
}