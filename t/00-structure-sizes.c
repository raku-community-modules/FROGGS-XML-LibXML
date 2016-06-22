#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include <libxml/tree.h>
#include <libxml/xpath.h>

#define s(name)     DLLEXPORT int sizeof_ ## name () { return sizeof(name); }

s(xmlAttr)
s(xmlAttributeType)
s(xmlBuffer)
s(xmlBufferAllocationScheme)
s(xmlChar)
s(xmlDoc)
s(xmlError)
s(xmlNode)
s(xmlNodeSet)
s(xmlNs)
s(xmlParserCtxt)
s(xmlParserInputState)
s(xmlParserMode)
s(xmlParserNodeInfo)
s(xmlParserNodeInfoSeq)
s(xmlSAXHandler)
s(xmlValidCtxt)
s(xmlXPathContext)
s(xmlXPathObject)
s(xmlElement)
