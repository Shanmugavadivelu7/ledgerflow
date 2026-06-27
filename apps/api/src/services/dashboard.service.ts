import prisma from "../config/prisma.js";

export async function getDashboardStats() {
  const customerCount = await prisma.customer.count();

  const saleCount = await prisma.sale.count();

  const totalSales = await prisma.sale.aggregate({
    _sum: {
      totalAmount: true,
    },
  });

  const creditSales = await prisma.sale.aggregate({
    where: {
      paymentStatus: "CREDIT",
    },
    _sum: {
      totalAmount: true,
    },
  });

  return {
    customerCount,
    saleCount,
    totalSales: totalSales._sum.totalAmount ?? 0,
    creditSales: creditSales._sum.totalAmount ?? 0,
  };
}