export interface AvailableVisitorCard {
  cardId: string;
  cardCode: string;
  label: string | null;
  lastUsed: string | null;
}

export interface AccessFamily {
  id: string;
  name: string;
  smiFamilyId: number | null;
  memberUserIds: string[];
}

export interface VisitorAssignment {
  assignmentId: string;
  cardId: string;
  cardCode: string;
  visitorId: string;
  company: string;
  visitedEntity: string | null;
  vehiclePlate: string | null;
  accessFamilyIds: string[];
  validFrom: string;
  validUntil: string;
  entryTime: string | null;
  exitTime: string | null;
  isCompleted: boolean;
}

export interface AssignVisitorCardPayload {
  cardId: string;
  visitorId: string;
  firstName?: string | null;
  lastName?: string | null;
  company?: string | null;
  visitedEntity?: string | null;
  vehiclePlate?: string | null;
  accessFamilyIds: string[];
  validFrom: string;
  validUntil: string;
}

export interface AssignVisitorCardResult {
  assignmentId: string;
  entryTime: string;
}
