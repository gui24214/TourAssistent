import QRCode from 'qrcode';

export default {
  register() {},

  bootstrap({ strapi }: { strapi: any }) {
    console.log("🚀 [SISTEMA QR] O Subscriber global (TS) foi carregado!");

    strapi.db.lifecycles.subscribe({
      models: ['api::item.item'], // Aplica-se à coleção Item

      async afterCreate(event) {
        const { result } = event;
        
        // No Strapi v5, usamos documentId ou id
        const targetId = result.documentId || result.id;

        console.log("🔥 [EVENTO] Novo Item detetado! ID:", targetId);

        if (targetId) {
          try {
            console.log("⚙️ [GERADOR] A criar Base64 para o QR Code...");
            
            // Gera o QR Code
            const qrCodeBase64 = await QRCode.toDataURL(targetId, {
              errorCorrectionLevel: 'H',
              margin: 1,
              width: 500
            });

            // Atualização via Query direta para evitar loops de hooks
            await strapi.db.query('api::item.item').update({
              where: { id: result.id },
              data: { qrCode: qrCodeBase64 },
            });

            console.log("✅ [SUCESSO] QR Code guardado no campo 'qrCode'.");
          } catch (err) {
            console.error("❌ [ERRO] Falha ao gerar QR Code:", err);
          }
        }
      },
    });
  },
};