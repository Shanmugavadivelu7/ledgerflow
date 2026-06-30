import prisma from "../config/prisma.js";
import { PaymentStatus } from "@prisma/client";

export async function getReport(
  type: string,
  customerId?: string
) {
  const now = new Date();

  let startDate = new Date();

  switch (type) {
    case "daily":
      startDate.setHours(0, 0, 0, 0);
      break;

    case "monthly":
      startDate = new Date(
        now.getFullYear(),
        now.getMonth(),
        1
      );
      break;

    case "yearly":
      startDate = new Date(
        now.getFullYear(),
        0,
        1
      );
      break;

    case "customer":
      if (!customerId) {
        throw new Error("Customer Id is required");
      }

      const customerSales = await prisma.sale.findMany({
        where: {
          customerId,
        },
        include: {
          customer: true,
        },
      });

      return {
        customer: customerSales[0]?.customer ?? null,
        billCount: customerSales.length,
        revenue: customerSales.reduce(
          (sum, sale) => sum + sale.totalAmount,
          0
        ),
        cash: customerSales
          .filter(
            (sale) =>
              sale.paymentStatus === PaymentStatus.PAID
          )
          .reduce(
            (sum, sale) => sum + sale.totalAmount,
            0
          ),
        credit: customerSales
          .filter(
            (sale) =>
              sale.paymentStatus === PaymentStatus.CREDIT
          )
          .reduce(
            (sum, sale) => sum + sale.totalAmount,
            0
          ),
      };

    default:
      startDate.setHours(0, 0, 0, 0);
  }

  const sales = await prisma.sale.findMany({
    where: {
      createdAt: {
        gte: startDate,
      },
    },
  });

  return {
    type,
    revenue: sales.reduce(
      (sum, sale) => sum + sale.totalAmount,
      0
    ),
    bills: sales.length,
    cash: sales
      .filter(
        (sale) =>
          sale.paymentStatus === PaymentStatus.PAID
      )
      .reduce(
        (sum, sale) => sum + sale.totalAmount,
        0
      ),
    credit: sales
      .filter(
        (sale) =>
          sale.paymentStatus === PaymentStatus.CREDIT
      )
      .reduce(
        (sum, sale) => sum + sale.totalAmount,
        0
      ),
  };
}