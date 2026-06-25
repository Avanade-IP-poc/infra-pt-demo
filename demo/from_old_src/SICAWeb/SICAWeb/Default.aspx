<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SICA - Sistema Integrado de Controlo de Acessos</title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display:none;">
            <asp:TextBox ID="txtComputerName" runat="server" Text=""></asp:TextBox>
            <asp:Label ID="lblAcesso" runat="server" Visible="false" Text=""></asp:Label>
        </div>
        <div >
            <table width="100%" height="100%">
			    <tr>
				    <td align="center" valign="center">
                        <p>
                            <asp:Image ID="Image1" runat="server" ImageUrl="images/sica.gif" />
                            <asp:Image ID="Image2" runat="server" ImageUrl="Images/wait_animated.gif" Visible="false" />
                        </p>
                        <p>
                            <asp:Label ID="lbllEmAutenticacao" runat="server" 
                                Text="A carregar. Aguarde por favor..." CssClass="corpotexto" 
                                Visible="False"></asp:Label>
                        </p>
				    </td>
			    </tr>
                <tr>
				    <td align="center" valign="bottom">
				        <asp:Label ID="lblTerminal" runat="server" Font-Overline="False" 
                            Font-Size="XX-Small"></asp:Label><br />
                            <asp:Label ID="lblMensagem" runat="server" Font-Overline="False" 
                            Font-Size="XX-Small"></asp:Label>
				    </td>
			    </tr>
		    </table>
        </div>
        <script type="text/javascript">
            //nome do pc físico
            //var net = new ActiveXObject("wscript.network");
            //document.forms["form1"].elements["txtComputerName"].value = net.ComputerName;

            //nome da máquina ligada a uma sessão de RDP
            //var _shell = new ActiveXObject("wscript.shell");
            //document.forms["form1"].elements["txtComputerName"].value = _shell.ExpandEnvironmentStrings("%CLIENTNAME%").toUpperCase();

            var pcName = "";
            var _shell = new ActiveXObject("wscript.shell");
            pcName = _shell.ExpandEnvironmentStrings("%CLIENTNAME%").toUpperCase();
            if (pcName == "%CLIENTNAME%") {
                var net = new ActiveXObject("wscript.network");
                pcName = net.ComputerName;
            }
            document.forms["form1"].elements["txtComputerName"].value = pcName;

            //var network = new ActiveXObject("WScript.Network");
            //network.ComputerName.toUpperCase()
            //}
        </script>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:Timer ID="Timer1" runat="server" Interval="500">
        </asp:Timer>
    </form>
</body>
</html>