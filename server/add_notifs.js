const PocketBase = require('pocketbase/cjs');

async function main() {
    const pb = new PocketBase('http://127.0.0.1:8090');
    await pb.admins.authWithPassword('admin@admin.com', 'admin1234'); // using default
    
    try {
        await pb.collections.create({
            name: "notifications",
            type: "base",
            listRule: "user = @request.auth.id",
            viewRule: "user = @request.auth.id",
            createRule: "",
            updateRule: "user = @request.auth.id",
            deleteRule: "user = @request.auth.id",
            schema: [
                { name: "user", type: "relation", required: true, options: { maxSelect: 1, collectionId: "_pb_users_auth_" } },
                { name: "sender", type: "relation", required: false, options: { maxSelect: 1, collectionId: "_pb_users_auth_" } },
                { name: "type", type: "text", required: true },
                { name: "title", type: "text", required: true },
                { name: "content", type: "text", required: true },
                { name: "action_data", type: "text", required: false },
                { name: "is_read", type: "bool", required: false }
            ]
        });
        console.log("Collection notifications créée !");
    } catch (e) {
        console.error("Erreur:", e.response?.data || e);
    }
}
main();
