import prisma from "../config/prisma.js";
import { PaymentStatus } from "@prisma/client";

export async function getDashboard() {
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const tomorrowStart = new Date(todayStart);
  tomorrowStart.setDate(tomorrowStart.getDate() + 1);

  const monthStart = new Date(
    todayStart.getFullYear(),
    todayStart.getMonth(),
    1
  );

  const [
    customers,
    sales,
    todaySales,
    monthSales,
  ] = await Promise.all([
    prisma.customer.count(),
    prisma.sale.findMany(),
    prisma.sale.findMany({
      where: {
        createdAt: {
          gte: todayStart,
          lt: tomorrowStart,
        },
      },
    }),
    prisma.sale.findMany({
      where: {
        createdAt: {
          gte: monthStart,
        },
      },
    }),
  ]);

  const todayRevenue = todaySales.reduce(
    (sum, sale) => sum + sale.totalAmount,
    0
  );

  const todayCash = todaySales
    .filter(
      (sale) => sale.paymentStatus === PaymentStatus.PAID
    )
    .reduce(
      (sum, sale) => sum + sale.totalAmount,
      0
    );

  const todayCredit = todaySales
    .filter(
      (sale) => sale.paymentStatus === PaymentStatus.CREDIT
    )
    .reduce(
      (sum, sale) => sum + sale.totalAmount,
      0
    );

  const monthRevenue = monthSales.reduce(
    (sum, sale) => sum + sale.totalAmount,
    0
  );

  return {
    today: {
      revenue: todayRevenue,
      bills: todaySales.length,
      cash: todayCash,
      credit: todayCredit,
    },
    month: {
      revenue: monthRevenue,
      bills: monthSales.length,
    },
    overall: {
      customers,
      sales: sales.length,
    },
  };
}