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

  return prisma.$transaction(async (tx) => {
    const sale = await tx.sale.create({
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
        items: true,
        customer: true,
      },
    });

    return sale;
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
