import type { Response } from "express";

export function successResponse<T>(
  res: Response,
  data: T,
  message = "Success",
  status = 200
) {
  return res.status(status).json({
    success: true,
    message,
    data,
  });
}

export function errorResponse(
  res: Response,
  message = "Something went wrong",
  status = 500,
  errors?: unknown
) {
  return res.status(status).json({
    success: false,
    message,
    errors,
  });
}