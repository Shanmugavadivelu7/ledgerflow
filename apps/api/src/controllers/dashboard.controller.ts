import type { Request, Response } from "express";
import { getDashboardStats } from "../services/dashboard.service.js";

export async function getDashboardHandler(
  _req: Request,
  res: Response
) {
  const stats = await getDashboardStats();

  return res.json(stats);
}