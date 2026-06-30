import prisma from "../config/prisma.js";
import { PaymentStatus } from "@prisma/client";

type SaleItemInput = {
  productName: string;
  quantity: number;
  unitPrice: number;
};

export async function createSale(
  customerId: string,
  paymentStatus: PaymentStatus,
  items: SaleItemInput[]
) {
  const totalAmount = items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  return prisma.sale.create({
    data: {
      customerId,
      totalAmount,
      paymentStatus,
      items: {
        createMany: {
          data: items.map((item) => ({
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          })),
        },
      },
    },
    include: {
      customer: true,
      items: true,
    },
  });
}

export async function getSales() {
  return prisma.sale.findMany({
    include: {
      customer: true,
      items: true,
    },
    orderBy: {
      createdAt: "desc",
    },
  });
}

export async function getSaleById(id: string) {
  return prisma.sale.findUnique({
    where: { id },
    include: {
      customer: true,
      items: true,
    },
  });
}

export async function getTodaySales() {
  const start = new Date();
  start.setHours(0, 0, 0, 0);

  return prisma.sale.findMany({
    where: {
      createdAt: {
        gte: start,
      },
    },
    include: {
      customer: true,
      items: true,
    },
    orderBy: {
      createdAt: "desc",
    },
  });
}

export async function getSalesByCustomer(customerId: string) {
  return prisma.sale.findMany({
    where: {
      customerId,
    },
    include: {
      customer: true,
      items: true,
    },
    orderBy: {
      createdAt: "desc",
    },
  });
}

export async function getSalesByDate(date: string) {
  const start = new Date(date);
  start.setHours(0, 0, 0, 0);

  const end = new Date(start);
  end.setDate(end.getDate() + 1);

  return prisma.sale.findMany({
    where: {
      createdAt: {
        gte: start,
        lt: end,
      },
    },
    include: {
      customer: true,
      items: true,
    },
    orderBy: {
      createdAt: "desc",
    },
  });
}

export async function deleteSale(id: string) {
  return prisma.sale.delete({
    where: {
      id,
    },
  });
}