import type { Request, Response } from "express";

import {
  createSale,
  getSales,
  getSaleById,
  getTodaySales,
  getSalesByCustomer,
  getSalesByDate,
  deleteSale,
} from "../services/sale.service.js";

import { successResponse } from "../utils/response.js";

export async function createSaleHandler(
  req: Request,
  res: Response
) {
  const { customerId, paymentStatus, items } = req.body;

  const sale = await createSale(
    customerId,
    paymentStatus,
    items
  );

  return successResponse(
    res,
    sale,
    "Sale created successfully",
    201
  );
}

export async function getSalesHandler(
  _req: Request,
  res: Response
) {
  const sales = await getSales();

  return successResponse(
    res,
    sales,
    "Sales fetched successfully"
  );
}

export async function getSaleByIdHandler(
  req: Request,
  res: Response
) {
  const sale = await getSaleById(
    String(req.params.id)
  );

  return successResponse(
    res,
    sale,
    "Sale fetched successfully"
  );
}

export async function getTodaySalesHandler(
  _req: Request,
  res: Response
) {
  const sales = await getTodaySales();

  return successResponse(
    res,
    sales,
    "Today's sales fetched successfully"
  );
}

export async function getSalesByCustomerHandler(
  req: Request,
  res: Response
) {
  const sales = await getSalesByCustomer(
    String(req.params.customerId)
  );

  return successResponse(
    res,
    sales,
    "Customer sales fetched successfully"
  );
}

export async function getSalesByDateHandler(
  req: Request,
  res: Response
) {
  const sales = await getSalesByDate(
    String(req.params.date)
  );

  return successResponse(
    res,
    sales,
    "Sales fetched successfully"
  );
}

export async function deleteSaleHandler(
  req: Request,
  res: Response
) {
  await deleteSale(
    String(req.params.id)
  );

  return successResponse(
    res,
    null,
    "Sale deleted successfully"
  );
}