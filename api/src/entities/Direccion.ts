import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Cliente } from "./Cliente.js";

@Entity({ name: "direcciones" })
export class Direccion {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "varchar", length: 10, nullable: true })
    calle!: string | null;

    @Column({ type: "varchar", length: 20, nullable: true })
    fraccionamiento!: string | null;

    @Column({ type: "varchar", length: 20, nullable: true })
    ciudad!: string | null;

    @Column({ type: "varchar", length: 20, nullable: true })
    estado!: string | null;

    @Column({ name: "codigo_postal", type: "varchar", length: 10, nullable: true })
    codigoPostal!: string | null;

    @Column({ name: "id_cliente", type: "int", unique: true })
    idCliente!: number;

    @OneToOne(() => Cliente, (cliente) => cliente.direccion)
    @JoinColumn({ name: "id_cliente", foreignKeyConstraintName: "fk_direcciones_clientes" })
    cliente?: Relation<Cliente>;
}
