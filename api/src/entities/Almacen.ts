import { Column, Entity, OneToMany, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Paquete } from "./Paquete.js";

@Entity({ name: "almacenes" })
export class Almacen {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "varchar", length: 50 })
    nombre!: string;

    @Column({ type: "varchar", length: 150 })
    ubicacion!: string;

    @Column({ name: "capacidad_maxima", type: "int" })
    capacidadMaxima!: number;

    @OneToMany(() => Paquete, (paquete) => paquete.almacen)
    paquetes?: Relation<Paquete[]>;
}
