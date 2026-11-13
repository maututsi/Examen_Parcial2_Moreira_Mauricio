import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Cliente } from "./Cliente.js";
import { Paquete } from "./Paquete.js";
import { HistorialRastreo } from "./HistorialRastreo.js";
import { AuditoriaEnvio } from "./AuditoriaEnvio.js";
import { StatusEnvio } from "./StatusEnvio.js";

@Entity({ name: "envios" })
export class Envio {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ name: "id_remitente", type: "int" })
    idRemitente!: number;

    @Column({ name: "id_destinatario", type: "int" })
    idDestinatario!: number;

    @Column({ name: "costo_total", type: "decimal", precision: 15, scale: 2 })
    costoTotal!: string;

    @Column({ type: "datetime" })
    fecha!: Date;

    @Column({ name: "status_global", type: "enum", enum: StatusEnvio })
    statusGlobal!: StatusEnvio;

    @ManyToOne(() => Cliente, (cliente) => cliente.enviosEnviados)
    @JoinColumn({ name: "id_remitente", foreignKeyConstraintName: "fk_envios_remitente" })
    remitente?: Relation<Cliente>;

    @ManyToOne(() => Cliente, (cliente) => cliente.enviosRecibidos)
    @JoinColumn({ name: "id_destinatario", foreignKeyConstraintName: "fk_envios_destinatario" })
    destinatario?: Relation<Cliente>;

    @OneToMany(() => Paquete, (paquete) => paquete.envio)
    paquetes?: Relation<Paquete[]>;

    @OneToMany(() => HistorialRastreo, (historial) => historial.envio)
    historial?: Relation<HistorialRastreo[]>;

    @OneToMany(() => AuditoriaEnvio, (auditoria) => auditoria.envio)
    auditorias?: Relation<AuditoriaEnvio[]>;
}
