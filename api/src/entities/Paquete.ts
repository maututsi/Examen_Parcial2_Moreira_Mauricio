import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Envio } from "./Envio.js";
import { Almacen } from "./Almacen.js";

@Entity({ name: "paquetes" })
export class Paquete {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "float" })
    peso!: number;

    @Column({ type: "float" })
    alto!: number;

    @Column({ type: "float" })
    largo!: number;

    @Column({ type: "float" })
    ancho!: number;

    @Column({ type: "varchar", length: 100 })
    contenido!: string;

    @Column({ name: "id_envio", type: "int", nullable: true })
    idEnvio!: number | null;

    // Almacén donde está el paquete ahora; null = fuera de almacén
    @Column({ name: "id_almacen", type: "int", nullable: true })
    idAlmacen!: number | null;

    @ManyToOne(() => Envio, (envio) => envio.paquetes, { nullable: true })
    @JoinColumn({ name: "id_envio", foreignKeyConstraintName: "fk_paquetes_envios" })
    envio?: Relation<Envio> | null;

    @ManyToOne(() => Almacen, (almacen) => almacen.paquetes, { nullable: true })
    @JoinColumn({ name: "id_almacen", foreignKeyConstraintName: "fk_paquetes_almacenes" })
    almacen?: Relation<Almacen> | null;
}
