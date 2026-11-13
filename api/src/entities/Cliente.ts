import { Column, Entity, OneToMany, OneToOne, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Direccion } from "./Direccion.js";
import { Envio } from "./Envio.js";

export enum StatusCliente {
    ACTIVO = "ACTIVO",
    INACTIVO = "INACTIVO",
}

@Entity({ name: "clientes" })
export class Cliente {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "varchar", length: 50 })
    nombres!: string;

    @Column({ type: "varchar", length: 50 })
    apellidos!: string;

    @Column({ name: "status_", type: "enum", enum: StatusCliente })
    status!: StatusCliente;

    @Column({ name: "limite_credito", type: "decimal", precision: 15, scale: 2 })
    limiteCredito!: string;

    @OneToOne(() => Direccion, (direccion) => direccion.cliente)
    direccion?: Relation<Direccion>;

    @OneToMany(() => Envio, (envio) => envio.remitente)
    enviosEnviados?: Relation<Envio[]>;

    @OneToMany(() => Envio, (envio) => envio.destinatario)
    enviosRecibidos?: Relation<Envio[]>;
}
