import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

/// Tela de Política de Privacidade (LGPD).
/// Pode ser aberta de forma independente (rota /privacy-policy) ou
/// embutida no fluxo de cadastro para coleta de consentimento.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: const PrivacyPolicyContent(),
        ),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    const titleStyle =
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark);
    const bodyStyle = TextStyle(fontSize: 16, height: 1.4, color: AppTheme.textMedium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Versão ${AppConstants.privacyPolicyVersion}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textMedium)),
        const SizedBox(height: 16),
        const Text('Quem cuida dos seus dados', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          'O Cuidar+ é o responsável pelo tratamento dos dados pessoais informados neste '
          'aplicativo. Em caso de dúvidas ou solicitações sobre seus dados, entre em '
          'contato pelo e-mail: contato@cuidarplus.app',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
        const Text('O que coletamos e por quê', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '• Nome, e-mail e senha: para criar e proteger sua conta.\n'
          '• Dados de saúde do idoso (medicações, horários, condições): para organizar '
          'lembretes e permitir que a família acompanhe o cuidado.\n'
          '• Registros de uso (horários de tomada de remédio, alertas): para gerar '
          'relatórios e notificar a família em caso de necessidade.\n\n'
          'Coletamos apenas o que é necessário para o funcionamento do app — não pedimos '
          'informações que não usamos.',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
        const Text('Com quem compartilhamos', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          'Os dados ficam visíveis apenas para os membros da mesma família cadastrados '
          'no app. O "QR Code Médico" é uma exceção: ele é público por natureza, para que '
          'um profissional de saúde possa acessar informações essenciais em uma emergência. '
          'Não vendemos nem compartilhamos seus dados com terceiros para fins comerciais.',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
        const Text('Por quanto tempo guardamos', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          'Mantemos seus dados enquanto sua conta estiver ativa. Se você excluir sua '
          'conta, seus dados pessoais e os registros vinculados a ela são apagados '
          'permanentemente em até 30 dias.',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
        const Text('Seus direitos', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          'A qualquer momento você pode, diretamente no app (em "Meu Perfil"):\n\n'
          '• Visualizar e exportar uma cópia dos seus dados.\n'
          '• Solicitar a exclusão da sua conta e dos seus dados.\n\n'
          'Você também pode pedir a correção de dados incorretos ou retirar seu '
          'consentimento entrando em contato pelo e-mail acima.',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
        const Text('Segurança', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          'Seus dados são armazenados de forma criptografada em trânsito (conexão '
          'segura HTTPS) e protegidos por regras de acesso que garantem que apenas '
          'você e sua família possam ver as informações cadastradas.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
