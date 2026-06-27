import prisma from "../config/prisma.js";

export async function createCustomer(
  name: string,
  phone?: string
) {
  return prisma.customer.create({
    data: {
      name,
      phone: phone ?? null,
    },
  });
}

export async function getCustomers() {
  return prisma.customer.findMany({
    orderBy: {
      createdAt: "desc",
    },
  });
}