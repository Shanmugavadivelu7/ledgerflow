import express from "express";
import cors from "cors";
import healthRouter from "./routes/health.route.js";
import customerRouter from "./routes/customer.route.js";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/health", healthRouter);
app.use("/customers", customerRouter);

export default app;
