import "reflect-metadata";
import { DataSource } from "typeorm";
import { Categoria } from "../entities/Categoria.js";
import { Producto } from "../entities/Producto.js";
import { Venta } from "../entities/Venta.js";
import { DetalleVenta } from "../entities/DetalleVenta.js";

export const AppDataSource = new DataSource({
    type: "mysql", // O "mariadb"
    host: process.env.DB_HOST ?? "localhost",
    port: Number(process.env.DB_PORT ?? 3308),
    username: process.env.DB_USER ?? "root",
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME ?? "ventas_db",
    synchronize: false, // Se mantiene false ya que las tablas fueron creadas previamente por SQL
    logging: true,
    entities: [Categoria, Producto, Venta, DetalleVenta],
    subscribers: [],
    migrations: [],
});
