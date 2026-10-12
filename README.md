# Driver de áudio do MacBook 12" — CS4208 — versão 0.5.5-rev3

Este pacote integra a implementação funcional de referência para o Cirrus Logic CS4208 do MacBook9,1/MacBook10,1 (A1534). Diferentemente do pacote anterior, ele substitui o codec Cirrus correspondente do stack HDA por uma versão adaptada que inicializa o amplificador dos alto-falantes internos, mantém o caminho analógico do fone, alterna por jack sensing e recompila o codec contra a árvore exata do kernel alvo via DKMS.

## Importante

Este é um driver experimental de baixo nível. A compilação e a instalação podem ser validadas fora do aparelho, mas o som físico, a troca automática, o volume, o suspend/resume e a ausência de ruído só podem ser confirmados no MacBook10,1 real. Não instale junto com o módulo identificador `macbook12_audio` da versão 0.4.x.

## Hardware confirmado

- DMI: `MacBook10,1`;
- codec: CS4208, subsystem `106b:6600`;
- fone: conversor `0x02` → pin `0x10`;
- alto-falante: conversor digital `0x0a` → pin `0x1d`;
- controlador HDA: Intel `8086:9d71`, subsystem `8086:7270`.

## Instalação no Mint 22.3 / kernel 7.0.0-31

Mantenha um kernel anterior no GRUB e faça backup:

```bash
sudo dkms status
sudo cp -a /etc/modprobe.d /etc/modprobe.d.macbook12-audio-backup
sudo apt install dkms build-essential gcc make curl dpkg-dev linux-headers-$(uname -r)
```

No Mint/Ubuntu, o instalador obtém automaticamente a fonte correspondente ao HWE ativo com `apt source linux-hwe-7.0` (ajustado à série do kernel), usando a árvore baixada na compilação. É necessário habilitar os repositórios `deb-src` e ter `dpkg-dev` instalado. Uma árvore explícita também pode ser informada com `--kernel-source DIR`.

```bash
chmod +x install.cirrus.driver.sh dkms.sh prepare.cirrus.driver.sh
sudo ./install.cirrus.driver.sh --install
sudo reboot
```

O instalador prepara uma cópia da fonte HDA, substitui somente o codec Cirrus nessa cópia, compila o módulo DKMS e não substitui `snd_hda_intel`.

## Verificação

```bash
dkms status
modinfo snd_hda_codec_cs420x | grep -E 'filename|version'
cat /proc/asound/cards
aplay -l
wpctl status
sudo dmesg | grep -Ei 'cs420|hda|snd|macbook|a1534|speaker|headphone'
```

Teste primeiro sem fone. Depois conecte e remova o fone durante uma reprodução curta e confirme fisicamente os dois caminhos.

## Volume e rollback

O caminho interno usa volume por software no PipeWire/WirePlumber. Copie apenas a variante correspondente em `contrib/wireplumber/` e reinicie o WirePlumber.

Se houver falha, ruído ou regressão:

```bash
sudo ./install.cirrus.driver.sh --uninstall
sudo dkms remove -m macbook12-audio-driver -v 0.5.5-rev3 --all || true
sudo depmod -a
sudo update-initramfs -u
sudo reboot
```

## Estado de garantia

A implementação funcional foi incorporada da referência pública `leifliddy/macbook12-audio-driver`, que declara suporte a MacBook9,1 e MacBook10,1. Este pacote local ainda requer confirmação no hardware do usuário; consulte `docs/TEST_PLAN.md`.
