import type { Request, Response } from "express";

import { getDashboard } from "../services/dashboard.service.js";
import { successResponse } from "../utils/response.js";

export async function getDashboardHandler(
  _req: Request,
  res: Response
) {
  const dashboard = await getDashboard();

  return successResponse(
    res,
    dashboard,
    "Dashboard fetched successfully"
  );
}