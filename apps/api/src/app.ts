import express from "express";
import cors from "cors";
import healthRouter from "./routes/health.route.js";
import customerRouter from "./routes/customer.route.js";
import { notFoundHandler } from "./middlewares/not-found.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
import saleRouter from "./routes/sale.route.js";
import dashboardRouter from "./routes/dashboard.route.js";
import reportRouter from "./routes/report.route.js";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/health", healthRouter);
app.use("/customers", customerRouter);
app.use("/sales", saleRouter);
app.use("/dashboard", dashboardRouter);
app.use("/reports", reportRouter);
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
