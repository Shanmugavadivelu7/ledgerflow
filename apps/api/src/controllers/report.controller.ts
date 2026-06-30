import type { Request, Response } from "express";

import { getReport } from "../services/report.service.js";
import { successResponse } from "../utils/response.js";

export async function getReportHandler(
  req: Request,
  res: Response
) {
  const type = String(req.query.type ?? "daily");

  const customerId =
    req.query.customerId !== undefined
      ? String(req.query.customerId)
      : undefined;

  const report = await getReport(
    type,
    customerId
  );

  return successResponse(
    res,
    report,
    "Report fetched successfully"
  );
}