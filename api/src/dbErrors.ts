export const getTriggerError = (e: unknown): string | null => {
    const driverError = (e as { driverError?: { sqlState?: string; errno?: number; sqlMessage?: string } })?.driverError;
    if (driverError?.sqlState === "45000" || driverError?.errno === 1644) {
        return driverError.sqlMessage ?? "Operación rechazada por la base de datos";
    }
    return null;
};
