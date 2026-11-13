#include <windows.h>

struct NppData {
    HWND nppHandle;
    HWND scintillaMainHandle;
    HWND scintillaSecondHandle;
};

struct SCNotification {
    NMHDR nmhdr;
};

struct ShortcutKey {
    bool isCtrl;
    bool isAlt;
    bool isShift;
    unsigned char key;
};

using PluginCommand = void (__cdecl *)();

struct FuncItem {
    wchar_t itemName[64];
    PluginCommand function;
    int commandId;
    bool initToCheck;
    ShortcutKey* shortcut;
};

namespace {
constexpr UINT NPPMSG = WM_USER + 1000;
constexpr UINT NPPM_GETCURRENTLANGTYPE = NPPMSG + 5;
constexpr UINT NPPM_GETNBUSERLANG = NPPMSG + 22;
constexpr UINT NPPM_MENUCOMMAND = NPPMSG + 48;
constexpr UINT NPPN_READY = 1001;
constexpr UINT NPPN_BUFFERACTIVATED = 1010;
constexpr int L_USER = 15;

NppData g_npp{};

void showInfo() {
    MessageBoxW(
        g_npp.nppHandle,
        L"Ativo: novas abas usam Markdown (Default).",
        L"Cadu Markdown Default",
        MB_OK | MB_ICONINFORMATION);
}

FuncItem g_functions[1] = {
    { L"Informacoes do Cadu Markdown Default", showInfo, 0, false, nullptr }
};

void applyMarkdownDefault() {
    if (!g_npp.nppHandle) {
        return;
    }

    int currentLanguage = 0;
    if (!SendMessageW(g_npp.nppHandle, NPPM_GETCURRENTLANGTYPE, 0,
                      reinterpret_cast<LPARAM>(&currentLanguage)) || currentLanguage != L_USER) {
        return;
    }

    int firstUserLanguageCommand = 0;
    const LRESULT userLanguageCount = SendMessageW(
        g_npp.nppHandle, NPPM_GETNBUSERLANG, 0,
        reinterpret_cast<LPARAM>(&firstUserLanguageCommand));

    if (userLanguageCount > 0 && firstUserLanguageCommand > 0) {
        // The returned ID is the generic "User Defined Language" command.
        // The first actual user language is the following menu item.
        SendMessageW(g_npp.nppHandle, NPPM_MENUCOMMAND, 0, firstUserLanguageCommand + 1);
    }
}
}

extern "C" __declspec(dllexport) void setInfo(NppData data) {
    g_npp = data;
}

extern "C" __declspec(dllexport) const wchar_t* getName() {
    return L"Cadu Markdown Default";
}

extern "C" __declspec(dllexport) FuncItem* getFuncsArray(int* count) {
    if (count) {
        *count = 1;
    }
    return g_functions;
}

extern "C" __declspec(dllexport) void beNotified(SCNotification* notification) {
    if (!notification) {
        return;
    }

    if (notification->nmhdr.code == NPPN_READY ||
        notification->nmhdr.code == NPPN_BUFFERACTIVATED) {
        applyMarkdownDefault();
    }
}

extern "C" __declspec(dllexport) LRESULT messageProc(UINT, WPARAM, LPARAM) {
    return TRUE;
}

extern "C" __declspec(dllexport) BOOL isUnicode() {
    return TRUE;
}
