import * as admin from 'firebase-admin';

if (admin.apps.length === 0) admin.initializeApp();

export { createVerdict } from './cases/createVerdict';
export { getUserUsage } from './cases/getUserUsage';
export { submitFeedback } from './cases/submitFeedback';
export { deleteCase } from './cases/deleteCase';
export { deleteAccount } from './account/deleteAccount';
export { revenueCatWebhook } from './billing/revenueCatWebhook';
