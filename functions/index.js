const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.scheduledComplaintEscalation = functions.pubsub
  .schedule("every 2 minutes")
  .onRun(async context => {
    const now = admin.firestore.Timestamp.now();

    const snapshot = await db
      .collection("complaint")
      .where("status", "==", "Pending")
      .get();

    if (snapshot.empty) {
      console.log("No pending complaints found.");
      return null;
    }

    const batch = db.batch();

    snapshot.forEach(doc => {
      const data = doc.data();
      const control = data.control;
      const date = data.date;
      const controlChangedDate = data.control_changed_date || date;

      if (!date || !controlChangedDate) {
        console.warn(`Document ${doc.id} missing date or control_changed_date`);
        return;
      }

      const elapsedSeconds = now.seconds - controlChangedDate.seconds;
      const elapsedMinutes = elapsedSeconds / 60;

      if (control === "FieldOfficer" && elapsedMinutes >= 2) {
        console.log(`Escalating complaint ${doc.id} from FieldOfficer to JuniorEngineer`);
        batch.update(doc.ref, {
          control: "JuniorEngineer",
          control_changed_date: now,
        });
      } else if (control === "JuniorEngineer" && elapsedMinutes >= 2) {
        console.log(`Escalating complaint ${doc.id} from JuniorEngineer to Commissioner`);
        batch.update(doc.ref, {
          control: "Commissioner",
          control_changed_date: now,
        });
      }
    });

    if (batch._ops.length === 0) {
      console.log("No complaints qualified for escalation at this time.");
      return null;
    }

    await batch.commit();
    console.log("Scheduled complaint escalation run complete.");
    return null;
  });
